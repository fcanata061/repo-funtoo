EAPI=6
inherit cmake-utils

DESCRIPTION="The AWS SDK for C++ provides a modern C++ (version C++ 11 or later) interface for Amazon Web Services (AWS)."
HOMEPAGE="https://aws.amazon.com/blogs/developer/aws-sdk-for-c-simplified-configuration-and-initialization/"

if [[ ${PV} = *9999* ]]; then
    inherit git-r3
    EGIT_REPO_URI="https://github.com/aws/aws-sdk-cpp.git"
else
    SRC_URI="https://github.com/aws/aws-sdk-cpp/archive/${PV}.tar.gz -> ${P}.tar.gz"
    S=${WORKDIR}/${PN}-cpp-${PV}
    KEYWORDS="~amd64 ~x86"
fi

LICENSE="Apache-2.0"
SLOT="0"

APIS="AWSMigrationHub access-management acm-pca acm alexaforbusiness apigateway application-autoscaling appstream appsync athena autoscaling-plans autoscaling batch budgets ce cloud9 clouddirectory cloudformation cloudfront cloudhsm cloudhsmv2 cloudsearch cloudsearchdomain cloudtrail codebuild codecommit codedeploy codepipeline codestar cognito-identity cognito-idp cognito-sync comprehend config connect cur datapipeline dax devicefarm directconnect discovery dms ds dynamodb dynamodbstreams ec2 ecr ecs elasticache elasticbeanstalk elasticfilesystem elasticloadbalancing elasticloadbalancingv2 elasticmapreduce elastictranscoder email es events firehose fms gamelift glacier glue greengrass guardduty health iam identity-management importexport inspector iot-data iot-jobs-data iot kinesis-video-archived-media kinesis-video-media kinesis kinesisanalytics kinesisvideo kms lambda lex-models lex lightsail logs machinelearning marketplace-entitlement marketplacecommerceanalytics mediaconvert medialive mediapackage mediastore-data mediastore meteringmarketplace mobile mobileanalytics monitoring mq mturk-requester opsworks opsworkscm organizations pinpoint polly-sample polly pricing queues rds redshift rekognition resource-groups resourcegroupstaggingapi route53 route53domains s3-encryption s3 sagemaker-runtime sagemaker sdb secretsmanager serverlessrepo servicecatalog servicediscovery shield sms snowball sns sqs ssm states storagegateway sts support swf text-to-speech transcribe transfer translate waf-regional waf workdocs workmail workspaces xray"

IUSE="tests static-libs unity-build +http +ssl +rtti $APIS"

RDEPEND="
    sys-libs/zlib
    http? ( net-misc/curl )
    ssl? ( dev-libs/openssl )
"

PATCHES=(
)

src_configure() {
    BUILD_ONLY="core;"
    IFS=' ' read -r -a apis <<< "$APIS"
    for api in "${apis[@]}" ; do
        $(use $api) && BUILD_ONLY="$api;${BUILD_ONLY}"
    done

    local mycmakeargs=(
        -DENABLE_TESTING=$(usex tests ON OFF)
        -DBUILD_SHARED_LIBS=$(usex static-libs OFF ON)
        -DENABLE_UNITY_BUILD=$(usex unity-build ON OFF)
        -DNO_HTTP_CLIENT=$(usex http OFF ON)
        -DNO_ENCRYPTION=$(usex ssl OFF ON)
        -DENABLE_RTTI=$(usex rtti ON OFF)
        -DBUILD_ONLY="${BUILD_ONLY::-1}"
    )

    cmake-utils_src_configure
}
